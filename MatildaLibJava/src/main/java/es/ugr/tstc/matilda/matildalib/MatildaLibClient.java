/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.matildalib;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
public class MatildaLibClient {

           BufferedReader in=null;
        PrintWriter out=null;
    
    enum Estados {inicial, inicializado};
    
    Estados estado=Estados.inicial;
    
    public static void main(String[] args){
        int libPort=9998;
        

        
        
        // Let's create the server
        new MatildaLibClient(libPort);
    }

    private MatildaLibClient(int libPort) {
        ServerSocket serverSocket;
        try {
            serverSocket = new ServerSocket(libPort);
        
            Socket socket = serverSocket.accept();
    
            crearProcesador(socket);
            
           
            
            serverSocket.close();
        } catch (IOException ex) {
            Logger.getLogger(MatildaLibClient.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * It processes the Matlib.gd Peer.
     * @param socket 
     */
    private void crearProcesador(Socket socket) {

        boolean salir=false;
                    
        try {

            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out=new PrintWriter(socket.getOutputStream(),true);
            
            // Let's read messages form Matilda.gd:
            do {
                Mensaje mensaje=new Mensaje(in);
                
                switch(estado){
                    case inicial:
                        if (mensaje.getType()==Mensaje.MessageType.libraryConnectionRequest){
                            
                            System.out.println("Conectando con aplicación: "+mensaje.getApplication());
                            
                            sendLibraryConnectionResponse(mensaje.getApplication());
                            
                            estado=Estados.inicializado;
                        }
                        break;
                    case inicializado:
//                          if (mensaje.getType()==Mensaje.MessageType.libraryChatMessage){
//                            System.out.println("Chat > "+mensaje.getMessage());
//                    
//                         enviarMensaje(mensaje.getMessage());
//                }
                     
                        break;
                }
                
            } while(!salir);
            
        } catch (IOException ex) {
            Logger.getLogger(MatildaLibClient.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                in.close();
                out.close();
            } catch (IOException ex) {
                Logger.getLogger(MatildaLibClient.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    private void enviarMensaje(String message) {
        
    }
    
    private void sendLibraryConnectionResponse(String name) {
        out.println("Hi:Ok:"+name);
    }
}
