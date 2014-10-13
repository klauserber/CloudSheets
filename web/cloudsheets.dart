import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';


void main() {
  //Button.use();  
  Transition.use();
  Collapse.use();
  
  
  $("#sidebarToggle").click((QueryEvent ev) {
    
    $("#sidebarContainer").toggle();    
  });
  
  $("#importButton").click((QueryEvent ev) {
    $("#filesInput")[0].style.display = "inline";
    $("#uploadButton")[0].style.display = "inline";
  });
  
  
  
}

