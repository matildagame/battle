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
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
public class CoberturaProtocolClientTest {
    
    public static void main(String[] args){
        int port=9090;
        String serverAddress="localhost";
        
        new CoberturaProtocolClientTest(serverAddress,port);
    }

    CoberturaProtocolClientTest(String serverAddress, int port) {
    
        try {
            String linea="";
            int error=0;
            
            Socket socket = new Socket(serverAddress,port);
            
            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter out = new PrintWriter(socket.getOutputStream());
            
            
            CoberturaMessage mensaje=new CoberturaMessage();
            
            mensaje.buildMJoinRequest("jjramos", 
                    new CharacterDescription("jjramos", 
                            "/root/Personajes/Matilda/matilda.mesh", 
                            "/root/Personajes/Matilda/materials/matilda1.material", 
                            "/root/Personajes/Matilda/materials/hair1.material", 
                            ""), "Room00");
            out.println(mensaje.serialize());
            out.flush();
            
           linea=in.readLine();
           mensaje.parsePacket(linea);
       
           
           switch(mensaje.getType()){
               case mJoinResponse:
                   switch(mensaje.getCode()){
                       case ErrorCode:
                           System.err.println("Client: No me deja unirme.");
                           error=1;
                           break;
                       case OKCode:
                           System.out.println("Client: Confirmación con éxito. Asignador identificador: \""+mensaje.getPlayerID()+"\"");
                               break;
                   }
                   break;
               default:
                   System.err.println("Client: Error. Recibido: \""+mensaje.serialize()+"\"");
                   error=1;
                   break;
           }
           
           // Esperemos a comenzar la partida:
           if(error==0){
           boolean empezarPartida=false;
           do {
               linea=in.readLine();
               mensaje.parsePacket(linea);
               
               switch(mensaje.getType()){
                   case mPlayerList:
                       System.out.println("Client: Nuevo listado de jugadores: ");
                       mostrarListaJugadores(mensaje.getPlayersList());
                       break;
                       
                   case mStartMatch:
                  System.out.println("Client: Comienza la partida!");

                       empezarPartida=true;
                       break;
                   
               }
           
           } while(!empezarPartida);
           }
            
        } catch (IOException ex) {
            Logger.getLogger(CoberturaProtocolClientTest.class.getName()).log(Level.SEVERE, null, ex);
        }
        
    }

    private void mostrarListaJugadores(List<CharacterDescription> playersList) {
        for(CharacterDescription jugador:playersList){
            System.out.println(" > "+jugador.getPlayerID()+"/"+jugador.getName());
        }
    }
}
