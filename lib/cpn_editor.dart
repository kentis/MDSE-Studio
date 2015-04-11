// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:paper_elements/paper_input.dart';
import 'package:polymer/polymer.dart';
import 'dart:js';
import 'dart:svg';
import 'dart:math';

import 'CPNPallette.dart';

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
      print("svg doubbleClicked");
      print(event.target);
      print(event.target.toString());
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
           print("created arc");
           Arc a = new Arc(from, to, svg);
           arcs.add(a);
        }
      }
    });
  }
}


class Arc  {
  
  SvgElement svg;
  
  Node from;
  Node to;
  
  PolylineElement  line;
  
  
  
  String inscription;
  
  Arc(from, to, svg){
    this.from = from;
    this.to = to;
    this.svg = svg;
    
    draw();
  }
  
  draw(){
     line = new PolylineElement();
     line.attributes['stroke'] = "black";
     
     line.attributes['x1'] = from.getX.toString();
     line.attributes['y1'] = from.getY.toString();
     
     line.attributes['x2'] = to.getX.toString();
     line.attributes['y2'] = to.getY.toString();
     line.attributes['render-order'] = "-1";
     line.attributes['points'] = ""+from.getX.toString()+","+from.getY.toString()+" "+to.getX.toString()+","+to.getY.toString();
     
     line.style.setProperty("z-index", "-100");
     line.style.setProperty("stroke", "black");
     line.style.setProperty("stroke-width", "2");
     
     line.attributes['marker-end'] = "url(#markerArrow)";
     
     from.getMovementListeners.add( (item) => resetPoints());
     to.getMovementListeners.add( (item) => resetPoints());
          
     
     svg.nodes.insert(0,line);
     
     
     if(from is Place){
       var points = ellipseLineIntersect(from,from.getX.toDouble(),from.getY.toDouble(),to.getX.toDouble(),to.getY.toDouble()   );
       /*
       for(var point in points){
         CircleElement ce = new CircleElement();
         //.cx = 1;
     
         ce.setAttribute('cx', point[0]);
         ce.setAttribute('cy', point[1]);
         ce.setAttribute('r',  "50");
         ce.setAttribute('fill', 'green');
     
         svg.append(ce);
       }*/
     }
          print("appended line");
     
  }
  
  void resetPoints(){
    double fromX = from.getX.toDouble();
    double fromY = from.getY.toDouble();
    /*if(from is Place){
      Place from_ = from as Place;
      double k = (to.getY - from.getY )/(to.getX - from.getX);
      int a = from_.ry;
      int b = from_.rx;
      
      double x = sqrt((a*a)+(k*k*b*b));
      double y = ((1/k)*sqrt((a*a)+(k*k*b*b)));
      
      print("fromX: $fromX fromY: $fromY");
      print("x: $x y: $y");
      
      fromX = fromX;//fromX + x;
      fromY = fromY;//fromY + y;
    }*/
    
    var fromPoints = ellipseLineIntersect(from,fromX.toDouble(),fromY.toDouble(),to.getX.toDouble(),to.getY.toDouble()   );
    var toPoints = ellipseLineIntersect(to,to.getX.toDouble(),to.getY.toDouble(),from.getX.toDouble(),from.getY.toDouble()   );
               
    
    line.attributes['points'] = ""+fromPoints[0][0].toString()+
        ","+fromPoints[0][1].toString()+" "+toPoints[0][0].toString()+","+toPoints[0][1].toString();
    
  }
  
  //
  //Inspired by: http://csharphelper.com/blog/2012/09/calculate-where-a-line-segment-and-an-ellipse-intersect-in-c/
  
  List ellipseLineIntersect(Place place, fromX, fromY, toX, toY){
    // Translate so the ellipse is centered at the origin.
    double cx = place.getX as double;
    double cy = place.getY as double;
    //rect.X -= cx;
    //rect.Y -= cy;
    fromX -= cx;
    fromY -= cy;
    toX -= cx;
    toY -= cy;
    
    double a = place.rx as double;
    double b = place.ry as double; 
    
    // Calculate the quadratic parameters.
    double A = (toX - fromX) * (toX - fromX) / a / a +
       (toY - fromY) * (toY - fromY) / b / b;
 
    double B = 2 * fromX * (toX - fromX) / a / a +
       2 * fromY * (toY - fromY) / b / b;
 
    double C = fromX * fromX / a / a + fromY * fromY / b / b - 1;

    // Make a list of t values.
    List<double> t_values = [];

    // Calculate the discriminant.
    double discriminant = B * B - 4 * A * C;
    if (discriminant == 0){
      // One real solution.
      t_values.add(-B / 2 / A);
    } else if (discriminant > 0){
      // Two real solutions.
      t_values.add(((-B + sqrt(discriminant)) / 2 / A));
      t_values.add(((-B - sqrt(discriminant)) / 2 / A));
    }
    
    List points = [];
    for (double t in t_values) {
      // If the points are on the segment (or we
      // don't care if they are), add them to the list.
      if (((t >= 0.toDouble()) && (t <= 1.toDouble()))) {
        double x = fromX + (toX - fromX) * t + cx;
        double y = fromY + (toY - fromY) * t + cy;
        points.add([x,y]);
      }
    }
    // Return the points.
    return points;
  }
}


abstract class Node {
  draw();
  
  int x;
  int y;

  int get getX => x;
  int get getY => y;
  
  SvgElement get getSvgElement;
  
  List movementListeners = [];
  
  List get getMovementListeners => movementListeners;
}

class Transition extends Node {

  SvgElement svg;
  
  String name = "Transition";
  
  bool selected = false;
  var dragStart;
  
  //EllipseElement ellipse;
  RectElement ell;
  SvgElement get getSvgElement => ell;
  
  Transition(x, y, svg) {
    this.x = x - 75;
    this.y = y - 75;
    this.svg = svg;
    draw();
  }

  
  draw() {
    ell = new RectElement();
    ell.attributes['x'] = x.toString();
    ell.attributes['y'] = y.toString();
    ell.attributes['height'] = "50";
    ell.attributes['width'] = "150";
    //ell.style.setProperty("fill", "red");
    ell.attributes['stroke'] = "black";
    ell.attributes['fill-opacity'] = "0.0";
    
    TextElement te = new TextElement();
        te.text = name;
        te.attributes['x'] = (x+5).toString();
        te.attributes['y'] = (y+10).toString();
            
    
    ell.onDragEnd.listen((event){
      print("dragged: "+event.client.toString());
    });
    
    ell.onClick.listen((event){
      print("clicked");
    });
    
    ell.onMouseDown.listen((event){
          print("down: "+event.client.toString());
          selected = true;
          dragStart = event.client; 
    });
    
    ell.onMouseUp.listen((event){
              print("up"+ event.client.toString());
        selected = false;          
    });
    
    ell.onMouseMove.listen((event){
      if(selected){
        x = x - (dragStart.x - event.client.x);
        y = y - (dragStart.y - event.client.y);
        dragStart = event.client;
        ell.attributes['x'] = x.toString();
        ell.attributes['y'] = y.toString();
        te.attributes['x'] = (x+5).toString();
        te.attributes['y'] = (y+25).toString();
        movementListeners.forEach((closure) => closure(this));
      }
    });
    
    //ell.onDoubleClick((event){
    //  print("clicked");
    //});
    
    
    svg.append(ell);
    svg.append(te);
  }

}


class Place extends Node{

  SvgElement svg;
  String name = "place";
  EllipseElement ellipse;

  SvgElement get getSvgElement => ellipse;
  
  int rx = 100;
  int ry = 50;
  
  bool selected = false;
  var dragStart;
    
  
  Place(x, y, svg) {
    this.x = x;
    this.y = y;
    this.svg = svg;
    draw();
  }

  
  
  draw() {
    ellipse = new EllipseElement();
    ellipse.attributes['cx'] =  x.toString();
    ellipse.attributes['cy'] = y.toString();
    ellipse.attributes['rx'] = rx.toString();
    ellipse.attributes['ry'] = ry.toString();
    ellipse.attributes['render-order'] = "1";
    //ellipse.attributes['transform'] = "translate(0 0)";
    ellipse.style.setProperty("fill", "white");
    ellipse.attributes['stroke'] = "black";
    ellipse.attributes['fill-opacity'] = "0.5";
    ellipse.style.setProperty("z-index", "100");
    //ellipse.draggable = true;
    //ellipse.onMouseDown((event)  { selectElement(event); });
    
    TextElement te = new TextElement();
            te.text = name;
            te.attributes['x'] = (x+5).toString();
            te.attributes['y'] = (y+25).toString();
        
    
    ellipse.onMouseDown.listen((event){
              print("down: "+event.client.toString());
              selected = true;
              dragStart = event.client; 
        });
        
    ellipse.onMouseUp.listen((event){
                  print("up"+ event.client.toString());
            selected = false;          
        });
        
    ellipse.onMouseMove.listen((event){
          //print("moved");
          if(selected){
            
            x = x - (dragStart.x - event.client.x);
            y = y - (dragStart.y - event.client.y);
            dragStart = event.client;
            ellipse.attributes['cx'] = x.toString();
            ellipse.attributes['cy'] = y.toString();
            movementListeners.forEach((closure) => closure(this));
          }
    });
    
    //ellipse.onDoubleClick((event){
    //      print("clicked");
    //});
        
    svg.append(ellipse);
  }
/*
  var selectedElement = null;
  var currentX = 0;
  var currentY = 0;
  var currentMatrix = null;

  void selectElement(evt) {
      selectedElement = evt.target;
      currentX = evt.clientX;
      currentY = evt.clientY;
      currentMatrix = selectedElement.getAttributeNS(null, "transform").slice(7,-1).split(' ');
         
      for(var i=0; i<currentMatrix.length; i++) {
        currentMatrix[i] = currentMatrix[i] as double ;
      }
     
      selectedElement.setAttributeNS(null, "onmousemove", "moveElement(evt)");
  }
  */
}
