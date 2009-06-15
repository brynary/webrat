var allLabels = inDocument.getElementsByTagName("label");
var candidateLabels = $A(allLabels).select(function(candidateLabel){
  var regExp = new RegExp('^' + locator + '\\b', 'i');
  var labelText = getText(candidateLabel).strip();
  return (labelText.search(regExp) >= 0);
});
if (candidateLabels.length == 0) {
  return null;      
}
candidateLabels = candidateLabels.sortBy(function(s) { return s.length * -1; }); //reverse length sort
var locatedLabel = candidateLabels.first();
var labelFor = locatedLabel.getAttribute('for');
if ((labelFor == null) && (locatedLabel.hasChildNodes())) {
  return locatedLabel.firstChild; //TODO: should find the first form field, not just any node
}
return selenium.browserbot.locationStrategies['id'].call(this, labelFor, inDocument, inWindow);
