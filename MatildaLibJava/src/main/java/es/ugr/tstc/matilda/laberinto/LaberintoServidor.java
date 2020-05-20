/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.laberinto;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
public class LaberintoServidor {
    
    List<HebraJugador> listaHebras;
            
       public static void main(String[] args){
       String servidor="localhost";
          int puerto=9090;
       
        new LaberintoServidor(servidor, puerto);
       }

    private LaberintoServidor(String servidor, int puerto) {
           try {
               boolean salir=false;
               
               listaHebras=new ArrayList<HebraJugador>();
               
               ServerSocket serverSocket=new ServerSocket(puerto);
               
               do{
                   
                   Socket socketConexion = serverSocket.accept();
                   
                   HebraJugador hebra=new HebraJugador(socketConexion,this);
                   aniadirHebra(hebra);
                   hebra.start();
                   
               } while(!salir);
           } catch (IOException ex) {
               Logger.getLogger(LaberintoServidor.class.getName()).log(Level.SEVERE, null, ex);
           }
     
    }

    synchronized private void aniadirHebra(HebraJugador hebra) {
        listaHebras.add(hebra);
    }
}
