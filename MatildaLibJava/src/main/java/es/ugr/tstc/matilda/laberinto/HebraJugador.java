/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.laberinto;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
public class HebraJugador extends Thread{

    private Socket socketConexion;
    private BufferedReader in;
    private PrintWriter out;
    private LaberintoServidor servidor;

    HebraJugador(Socket socketConexion,LaberintoServidor servidor) {
        try {
            this.socketConexion=socketConexion;
            
            in = new BufferedReader(new InputStreamReader(socketConexion.getInputStream()));
            out=new PrintWriter(socketConexion.getOutputStream());
            
            this.servidor=servidor;
        } catch (IOException ex) {
            Logger.getLogger(HebraJugador.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    public void run() {
        boolean salir=false;
       do{
      
            try {    
                
                String linea=in.readLine();
                
                System.out.println("ServidorLaberinto: recibido "+linea);
                
            } catch (IOException ex) {
                Logger.getLogger(HebraJugador.class.getName()).log(Level.SEVERE, null, ex);
            }
       } while(!salir);
       }
    
    
    
}
