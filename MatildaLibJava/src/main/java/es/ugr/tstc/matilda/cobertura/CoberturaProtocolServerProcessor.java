/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.cobertura;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
public class CoberturaProtocolServerProcessor extends Thread {

    private BufferedReader in;
    private PrintWriter out;
    private EventAndMessageQueue eventQueue;
    private final CoberturaProtocolServer servidor;
    private final Socket socketConexion;

  
    
    
    // Estados del protocolo:
    enum ESTADOS {
        inicial, esperandoInicioPartida, enPartida, fin
    };
    ESTADOS estado = ESTADOS.inicial;
   

    public CoberturaProtocolServerProcessor(Socket socketConexion_, CoberturaProtocolServer mainServer) {
        servidor=mainServer;
            socketConexion = socketConexion_;
                    
                          eventQueue = new EventAndMessageQueue();
        try {

            
            in = new BufferedReader(new InputStreamReader(socketConexion.getInputStream()));
            out = new PrintWriter(socketConexion.getOutputStream());
            
      
        } catch (IOException ex) {
            Logger.getLogger(CoberturaProtocolServerProcessor.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    public void run() {
    
    // private void servirCliente() {


            // Creamos una hebra que siempre va a estar arecibiendo paquetes, en background:
            ReaderThread readerThread = new ReaderThread(in, eventQueue);
            readerThread.start();

            do {
                Event event = eventQueue.waitForEvent();

                System.out.println("Servidor: recibido: "+event.show());
                
                // Según el estado del protocolo del lado del servidor:
                switch (estado) {
                    case inicial:
                        procesarEstadoInicial(event);
                        break;
                    case esperandoInicioPartida:
                        procesarEstadoEsperandoInicioPartida(event);
                        break;
                    case enPartida:
                        procesarEstadoEnPartida(event);
                        break;
                    case fin:
                        break;
                    default:
                        break;
                }

            } while (estado != ESTADOS.fin);

      
        try {
            socketConexion.close();
        } catch (IOException ex) {
            Logger.getLogger(CoberturaProtocolServerProcessor.class.getName()).log(Level.SEVERE, null, ex);
        }
            
    }
    
    void addEvent(Event event) {
        eventQueue.queue(event);
    }
    
     
    /**
     * Clase secundaria para leer en segundo plano los paquetes que lleguen, y
     * así no bloquear el resto del servidor:
     */
    public class ReaderThread extends Thread {

        BufferedReader in;
        EventAndMessageQueue queue;

        ReaderThread(BufferedReader in, EventAndMessageQueue queue) {
            this.in = in;
            this.queue = queue;
        }

        @Override
        public void run() {
            boolean finish = false;
            do {
                CoberturaMessage message = obtenerMensaje(in);
                queue.queue(message);
            } while (!finish);
        }

        private CoberturaMessage obtenerMensaje(BufferedReader in) {
            String linea = null;
            String mensajeCrudo = "";
            CoberturaMessage mensaje = null;

            try {
                // Esto debería ser lectura de una cola de eventos:
                linea = in.readLine();
                mensajeCrudo = linea;
                mensaje = new CoberturaMessage(mensajeCrudo);

            } catch (IOException ex) {
                Logger.getLogger(CoberturaProtocolServer.class.getName()).log(Level.SEVERE, null, ex);
            }

            return mensaje;
        }

    }

    /**
     *
     * @param mensaje
     */
    private void procesarEstadoInicial(Event event) {

        if (event.isMessage()) {
            CoberturaMessage mensaje = event.getMessage();
            switch (mensaje.getType()) {
                case mJoinRequest:

                    //Veamos si ya existe un usuario parecido:
                    if (!servidor.existeUsuario(mensaje.getUsername())) {
                        if (servidor.existeHabitacion(mensaje.getRoom())) {
                            String playerID = servidor.generatePlayerID(mensaje.getUsername(), (CharacterDescription) mensaje.getCharacterDescription(), mensaje.getRoom());
                            CharacterDescription characterDescription = mensaje.getCharacterDescription();
                            characterDescription.setPlayerID(playerID);

                            // En el servidor de juegos se añade otro jugador:
                            servidor.addPlayer(playerID, characterDescription);

                            enviarMJoinResponseOk(playerID);

                            estado = ESTADOS.esperandoInicioPartida;
                        } else {
                            error();
                            enviarMJoinResponseErrRoom();
                        }
                    } else {
                        error();

                        enviarMJoinResponseErrUsername();
                    }

                    break;
                default:
                    error();
                    break;
            }
        } else {
            // Ha llegado un evento:
             switch(event.getSubtype()){
                case evIniciarPartida:
                    Map<String, float[]> spawnPlayerList=servidor.getSpawnPlayerList();
                    enviarMStartMatch(servidor.getRoom(),spawnPlayerList);
                    estado=ESTADOS.enPartida;
                    break;
                default:
                    error();
                    break;
            }
        }
    }

    private void procesarEstadoEsperandoInicioPartida(Event event) {
        if (event.isMessage()) {
            // Si es un mensaje:
            CoberturaMessage mensaje = event.getMessage();

            switch (mensaje.getType()) {
                case mLeave:
                    servidor.removePlayer(mensaje.getUsername(), mensaje.getRoom());
                    estado = ESTADOS.fin;
                    break;
                default:
                    error();
                    break;
            }
        } else {
            // Si es un evento:
            switch(event.getSubtype()){
                case evCambiarLista:
                    List<CharacterDescription> playerList=servidor.getPlayerList();
                    enviarMPlayerList(playerList);
                    
                    break;
                default:
                    break;
            }
        }
    }
    
    private void procesarEstadoEnPartida(Event event) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }


    private void enviarMJoinResponseErrRoom() {
        CoberturaMessage message = new CoberturaMessage();
        message.buildMJoinResponse("", CoberturaMessage.CODES.ErrorCode);
        out.print(message.serialize());
    }

    private void enviarMJoinResponseErrUsername() {
        CoberturaMessage message = new CoberturaMessage();
        message.buildMJoinResponse("", CoberturaMessage.CODES.ErrorCode);
        out.print(message.serialize());
    }

    private void enviarMJoinResponseOk(String playerID) {
        CoberturaMessage message = new CoberturaMessage();
        message.buildMJoinResponse(playerID, CoberturaMessage.CODES.OKCode);
        out.print(message.serialize());
    }
    
    private void enviarMPlayerList(List<CharacterDescription> playersList) {
        CoberturaMessage message = new CoberturaMessage();
        message.buildMPlayerList(playersList);
        out.print(message.serialize());
    }
    
    private void enviarMStartMatch(String room,  Map<String, float[]> spawnPlayersList) {
        CoberturaMessage message = new CoberturaMessage();
        message.buildMStartMatch(room, spawnPlayersList);
        out.print(message.serialize());
    }
    
     private void error() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

   

}
