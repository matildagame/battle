/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.cobertura;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Semaphore;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
public class EventAndMessageQueue {
    List <Event> queue;

    Semaphore available;

    public EventAndMessageQueue() {
        available=new Semaphore(0);
        queue=new ArrayList<Event>();
        
    }
    
    
    synchronized void queue(CoberturaMessage message) {
        queue.add(new Event(message));
        available.release();
    }
    
    synchronized void queue(Event event) {
        queue.add(event);
        available.release();
    }
    
    synchronized Event dequeue(){
        return queue.remove(0);
    }
    
    Event waitForEvent() {
        Event event=null;
        
        try {
            
            available.acquire();
            return dequeue();
            
        } catch (InterruptedException ex) {
            Logger.getLogger(EventAndMessageQueue.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        return event;
    }

   
    
}
