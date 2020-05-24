/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.transport;

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
public class TransportEntity {
    
    public static final int UndeterminedMode=-1;
    public static final int ServerMode=0;
    public static final int ClientMode=1;
    public static final int ConnectionMode=2;
    
    int mode=UndeterminedMode;
            
    int port=-1;
    String serverAddress="localhost";
    private ServerSocket serverSocket;
    private Socket socket;
    private PrintWriter out;
    private BufferedReader in;
    
    
    public enum STATE {Connected,Disconnected,Waiting};
    public STATE state=STATE.Disconnected;
    
    public STATE getStatus(){
        return state;
    }
    
    public TransportEntity(int mode, int port) {
        this.mode=mode;
        this.port=port;
    }
    
        public TransportEntity(int mode, String serverAddress,int port) {
            this.serverAddress=serverAddress;
        this.mode=mode;
        this.port=port;
    }

    private TransportEntity(int mode) {
        this.mode=mode;
    }

    public int send(String message) {
        int error=0;
        
        System.out.println("[TODO] Enviado -> "+message);
        
        return error;
    }

    public int initialize() {
        int error = 0;

        if (mode == ServerMode) {
            error = initializeServer(port);
            if (error == 0) {
                state = STATE.Waiting;
            }
        } else if (mode == ClientMode) {
            error = initializeClient(serverAddress, port);
            if (error == 0) {
                state = STATE.Connected;
            }

        } else {
            error = -1;
        }
        
        return error;
    }

    private int initializeServer(int port) {
        int error=0;
        
        try {
            serverSocket = new ServerSocket(port);
            state=STATE.Waiting;
            
        } catch (IOException ex) {
            Logger.getLogger(TransportEntity.class.getName()).log(Level.SEVERE, null, ex);
            error=-1;
            state=STATE.Disconnected;
        }
       
        return error;
    }

    private int initializeClient(String serverAddress, int port) {
        int error=0;
        
        try {
            socket=new Socket(serverAddress,port);
            
            out=new PrintWriter(socket.getOutputStream());
            in=new BufferedReader(new InputStreamReader(socket.getInputStream()));
            
        } catch (IOException ex) {
            Logger.getLogger(TransportEntity.class.getName()).log(Level.SEVERE, null, ex);
            error=-1;
        }
        
        return error;
    }

    public TransportEntity waitForConnectionRequest() {
        TransportEntity te=new TransportEntity(TransportEntity.ConnectionMode);
        
        try {
            
            state=STATE.Waiting;
            socket=serverSocket.accept();
            
            out=new PrintWriter(socket.getOutputStream());
            in=new BufferedReader(new InputStreamReader(socket.getInputStream()));
            
        } catch (IOException ex) {
            Logger.getLogger(TransportEntity.class.getName()).log(Level.SEVERE, null, ex);
            te=null;
        }
        
        return te;
    }

    public byte[] receivePacket() {
        byte [] packet=null;
        
        try {
            String linea=in.readLine();
            
            packet=linea.getBytes("ASCII");
            
        } catch (IOException ex) {
            Logger.getLogger(TransportEntity.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        
        return packet;
    }
    
}
