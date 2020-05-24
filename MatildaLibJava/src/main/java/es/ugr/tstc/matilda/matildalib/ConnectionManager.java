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
import java.net.Socket;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
public class ConnectionManager {

    Socket socket=null;
    private BufferedReader in;
    private PrintWriter out;
    
    int connect(String servidor, int puerto) {
        int error=0;
        
        try {
            socket=new Socket(servidor,puerto);
            
            in=new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out=new PrintWriter(socket.getOutputStream(),true);
            
        } catch (IOException ex) {
            Logger.getLogger(ConnectionManager.class.getName()).log(Level.SEVERE, null, ex);
            error=1;
        }
        
        return error;
    }

    int sendSpawnRequest(String object, String name) {
        int error=0;
        
        out.println("SPAWN:"+object+":"+name);

        return error;
    }
    
}
