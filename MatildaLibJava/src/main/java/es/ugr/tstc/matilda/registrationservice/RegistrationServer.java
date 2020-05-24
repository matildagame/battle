/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.registrationservice;

import es.ugr.tstc.matilda.transport.TransportEntity;

/**
 *
 * @author matilda
 */
public class RegistrationServer {

    TransportEntity transportEntity = null;
    private final UserDataBase database;


    enum STATE {
        InitialState
    };

    STATE state = STATE.InitialState;

    public static void main(String[] args) {
        int port = 9991;

        // Let's create the server
        new RegistrationServer(port);
    }

    private RegistrationServer(int port) {
        int error = 0;

        database = new UserDataBase("default.db");

        transportEntity = new TransportEntity(TransportEntity.ServerMode, port);
        error = transportEntity.initialize();

        if (error == 0) {
            boolean exitServer = false;

            // It's an iterative server...
            do {
                TransportEntity connection = transportEntity.waitForConnectionRequest();

                processClient(connection);

            } while (!exitServer);

        } else {
            System.err.println("RegistrationServer. Error: Couldn't create server socket.");
        }

    }

    private void processClient(TransportEntity connection) {
        boolean finishService = false;

        do {

            byte[] packet = connection.receivePacket();
            RegistrationMessage message = new RegistrationMessage(packet);

            switch (state) {
                case InitialState:

                    switch (message.getType()) {
                        case RegistrationMessage.RegisterRequestType:

                            // Let's verify whether it exists or not... It's a fake databse, every user with password==username exists XD.
                            UserInfo userData = database.checkUser(message.getName(), message.getPassword());

                            if (userData != null) {
                                sendRegistratioResponseError();
                            } else {
                                userData.setToken(generateToken(userData.getName()+"/"+"random"));
                                userData.setState(UserInfo.STATES.Registered);
                                sendRegistrationResponseOk(userData.getToken());
                            }

                            break;
                    }

                    break;
                default:
                    break;
            }
        } while (!finishService);
    }
    
        private void sendRegistratioResponseError() {
        RegistrationMessage message=new RegistrationMessage(RegistrationMessage.RegisterResponseType,RegistrationMessage.ERROR.UserUnknown);
        transportEntity.send(message.serialize());
    }

    private String generateToken(String token) {
       return token+";"+"nonce";
    }

    private void sendRegistrationResponseOk(String token) {
        RegistrationMessage message=new RegistrationMessage(RegistrationMessage.RegisterResponseType,RegistrationMessage.ERROR.NoError,token);
        transportEntity.send(message.serialize());
    }

}
