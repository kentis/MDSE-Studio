// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
//import 'package:paper_elements/paper_input.dart';
import 'package:polymer/polymer.dart';
//import 'dart:js';
import 'dart:svg';
import 'dart:math';

import 'CPNPallette.dart';
import 'node.dart';
import 'arc.dart';

/// A Polymer `<main-app>` element.
@CustomTag('cpn-editor')
class CPNEditor extends PolymerElement {

  Object clicked;
  
  Map svgElemToNode = {};
  List nodes = [];
  List arcs = [];
  int offset1 = 200;
  /// Constructor used to create instance of MainApp.
  CPNEditor.created() : super.created();


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

  /// Called when main-app has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {
    super.ready();

    SvgElement svg = this.shadowRoot.getElementById('editor');
    svg.style.setProperty("background-color", "#D8D8F2");

 
    
    svg.onDoubleClick.listen((event) {
      //print("svg doubbleClicked");
      //print(event.target);
      //print(event.target.toString());
      //print(event.target )
      if(CPNPallette.selected() == "place"){ 
        var p = new Place(event.client.x - offset1, event.client.y, svg);
        nodes.add(p);
        svgElemToNode[p.getSvgElement] = p;
      } else if(CPNPallette.selected() == "transition"){
        var t = new Transition(event.client.x - offset1, event.client.y, svg);
        nodes.add(t);
        svgElemToNode[t.getSvgElement] = t;
      } else if(CPNPallette.selected() == "arc"){
        if(clicked == null){
          if(event.target is EllipseElement || event.target is RectElement){
            //EllipseElement t = event.target;
            print("clicked node");
            clicked = event.target;
          }
        } else if(event.target is EllipseElement || event.target is RectElement){
           print("clicked node again"); 
           var from = svgElemToNode[clicked];
           var to = svgElemToNode[event.target];
           //print("created arc");
           Arc a = new Arc(from, to, svg);
           arcs.add(a);
           clicked = null;
        }
      }
    });
  }
}




