/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.registrationservice;

/**
 *
 * @author matilda
 */
public class UserInfo {

    UserInfo(String name, String password, STATES state) {
        this.name=name;
        this.password=password;
        this.state=state;
    }

    void setState(STATES state) {
        this.state=state;
    }
    
    public enum STATES {Unregistered,Registered};
    
    STATES state=STATES.Unregistered;
    
    String name;
    String password;
    String token;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
