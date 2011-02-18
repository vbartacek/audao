package com.spoledge.audao.test.client.gwtemul;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;

import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.RootPanel;

import com.google.appengine.api.datastore.*;

import com.spoledge.audao.test.gwt.dto.*;


/**
 * The main class of this module.
 */
public class GWTEmulPage implements EntryPoint {
    private GwtBasic basic = new GwtBasic();
    private GwtGoogle google = new GwtGoogle();
    private GwtListGoogle lgoogle = new GwtListGoogle();


    ////////////////////////////////////////////////////////////////////////////
    // Constructors
    ////////////////////////////////////////////////////////////////////////////

    public GWTEmulPage() {
    }


    ////////////////////////////////////////////////////////////////////////////
    // EntryPoint
    ////////////////////////////////////////////////////////////////////////////

    /**
     * This is the entry point method.
     */
    public void onModuleLoad() {
        RootPanel.get("gwt").add( new Label("It works !!") );
    }

}
