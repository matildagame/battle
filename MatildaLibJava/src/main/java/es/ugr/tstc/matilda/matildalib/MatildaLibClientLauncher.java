/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.matildalib;

/**
 *
 * @author matilda
 */
public class MatildaLibClientLauncher {

    MatildaLibClient matildaClient;
    
    public MatildaLibClientLauncher(int libPort) {
        matildaClient=new MatildaLibClient(libPort);
        // We use the default managers, but they could be the ones from the students.
        matildaClient.setChatManager(new ChatManager());
        matildaClient.setConnectionManager(new ConnectionManager());
        matildaClient.setGameObjectManager(new GameObjectManager());
        matildaClient.setRegistrationManager(new RegistrationManager());
        
        if(matildaClient.init()!=0){
            System.err.println("Error al incializar MatildaLib");
        }
    }
    
    
     public static void main(String[] args){
        int libPort=9998;
        
        // Let's create the server
        new MatildaLibClientLauncher(libPort);
    }
}
