package com.bayer.ipms.view.events;


public class ContextualEventReceiver {
    public ContextualEventReceiver() {
        super();
    }
    
    public void receiveEvent(Object payload, ContextualEventHandler eventHandler){
        eventHandler.handleEvent(payload);
    }
}
