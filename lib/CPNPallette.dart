// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:paper_elements/paper_input.dart';
import 'package:polymer/polymer.dart';



/// A Polymer `<main-app>` element.
@CustomTag('cpn-pallette')
class CPNPallette extends PolymerElement {

  static String selectedPallette = "";
  
  static String selected() { return selectedPallette; }
  
  /// Constructor used to create instance of MainApp.
  CPNPallette.created() : super.created();

  void reverseText(Event event, Object object, PaperInput target) {
    //reversed = target.value.split('').reversed.join('');
  }

  // Optional lifecycle methods - uncomment if needed.

//  /// Called when an instance of main-app is inserted into the DOM.
//  attached() {
//    super.attached();
//  }

//  /// Called when an instance of main-app is removed from the DOM.
//  detached() {
//    super.detached();
//  }

//  /// Called when an attribute (such as a class) of an instance of
//  /// main-app is added, changed, or removed.
//  attributeChanged(String name, String oldValue, String newValue) {
//    super.attributeChanges(name, oldValue, newValue);
//  }

//  /// Called when main-app has been fully prepared (Shadow DOM created,
//  /// property observers set up, event listeners attached).
  ready() {
    super.ready();
    this.shadowRoot.getElementById("place").onClick.listen((event){
      if(selectedPallette == "place"){
        selectedPallette == "";
      } else {
      selectedPallette = "place"; 
      }
    });
    
    this.shadowRoot.getElementById("transition").onClick.listen((event){
      if(selectedPallette == "transition"){
              selectedPallette == "";
            } else {
              selectedPallette = "transition";        
            }
       
    });
        
    this.shadowRoot.getElementById("arc").onClick.listen((event){
      if(selectedPallette == "arc"){
              selectedPallette == "";
            } else {
              selectedPallette = "arc";         
            }
      
    });
        
  }
}
