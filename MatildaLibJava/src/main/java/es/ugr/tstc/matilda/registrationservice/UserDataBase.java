/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.registrationservice;

import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author matilda
 */
public class UserDataBase {

    Map <String,UserInfo> database;
    
    UserDataBase(String file) {
        database=new HashMap<String,UserInfo>();
    }

    UserInfo checkUser(String name, String password) {
        UserInfo ui=null;
    
        ui=database.get(name);
        
        if(ui==null){
            // Bogus verification... if name==password, it exists XD
            if(name.compareTo(password.toUpperCase())==0){
                ui=new UserInfo(name,password,UserInfo.STATES.Unregistered);
            }
        }
        
        return database.get(name);
    }
    
}
