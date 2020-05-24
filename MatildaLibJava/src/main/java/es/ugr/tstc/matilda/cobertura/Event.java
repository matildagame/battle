/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.cobertura;

import java.util.Map;

/**
 *
 * @author matilda
 */
public class Event {

    Event(EVENTS evento, Map<String, CharacterDescription> playersList) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    String show() {
       return " > "+message.getType();
    }

    enum TYPE {
        message, event
    };
    TYPE eventType;

    enum EVENTS {
        evCambiarLista, evIniciarPartida, evFinPartida
    };
    EVENTS eventSubtype;

    CoberturaMessage message = null;

    Event(CoberturaMessage message) {
        eventType = TYPE.message;
        this.message = message;
    }

    boolean isMessage() {
        return eventType == TYPE.message;
    }

    boolean isEvent() {
        return eventType == TYPE.event;
    }
    
    CoberturaMessage getMessage(){
        return message;
    }

    EVENTS getSubtype(){
        return eventSubtype;
    }
}
