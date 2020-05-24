package es.ugr.tstc.matilda.cobertura;

import es.ugr.tstc.matilda.laberinto.LaberintoServidor;
import es.ugr.tstc.matilda.registrationservice.UserDataBase;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author jjramos@ugr.es
 */
public class CoberturaProtocolServer {
    

    private CoberturaServer application;
    private List<CoberturaProtocolServerProcessor> processorList;

 
           public static void main(String[] args){
               
               int puerto=9090;
               // Application LEvel part of the server:
               CoberturaServer application=new CoberturaServer();
               application.init();
               application.setRoom("Room00");
               
               // Main part of the server: it waits for players, and
               // launches a thread for each client.
               new CoberturaProtocolServer(puerto, application);
           }

/**
 * 
 * @param puerto
 * @param application 
 */
    public CoberturaProtocolServer(int puerto, CoberturaServer application) {
       
        this.application=application;
        ServerSocket socketServicio = null;
        
        processorList=new ArrayList<CoberturaProtocolServerProcessor>();
        
        boolean salirServidor = false;

        try {
            

            socketServicio = new ServerSocket(puerto);

            Socket socketConexion = socketServicio.accept();

            do {
                // Por cada cliente, creamos una hebra:
                CoberturaProtocolServerProcessor processor=new CoberturaProtocolServerProcessor(socketConexion,this);
                processorList.add(processor);
                processor.start();
                
            } while (!salirServidor);

        } catch (IOException ex) {
            Logger.getLogger(CoberturaProtocolServer.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

     void notifyPlayerList(Map<String, CharacterDescription> playersList) {
        for(CoberturaProtocolServerProcessor thread:processorList){
            thread.addEvent(new Event(Event.EVENTS.evCambiarLista,playersList));
        }
    }

    boolean existeUsuario(String username) {
        return application.existeUsuario(username);
    }

    boolean existeHabitacion(String room) {
        return application.existeHabitacion(room);
    }

    String generatePlayerID(String username, CharacterDescription characterDescription, String room) {
        return application.generatePlayerID(username, characterDescription, room);
    }

    void addPlayer(String playerID, CharacterDescription characterDescription) {
        application.addPlayer(playerID, characterDescription);
    }

    Map<String, float[]> getSpawnPlayerList() {
     return application.getSpawnPlayerList();
    }

    String getRoom() {
        return application.getRoom();
    }

    void removePlayer(String username, String room) {
     application.removePlayer(username, room);
    }

    List<CharacterDescription> getPlayerList() {
        return application.getPlayerList();
    }

}
