RegExp.escape = function(text) {
  if (!arguments.callee.sRE) {
    var specials = [
      '/', '.', '*', '+', '?', '|',
      '(', ')', '[', ']', '{', '}', '\\'
    ];
    arguments.callee.sRE = new RegExp(
      '(\\' + specials.join('|\\') + ')', 'g'
    );
  }
  return text.replace(arguments.callee.sRE, '\\$1');
}

var allLabels = inDocument.getElementsByTagName("label");
var regExp = new RegExp('^\\W*' + RegExp.escape(locator) + '(\\b|$)', 'i');

var candidateLabels = $A(allLabels).select(function(candidateLabel){
  var labelText = getText(candidateLabel).strip();
  return (labelText.search(regExp) >= 0);
});

if (candidateLabels.length == 0) {
  return null;      
}

//reverse length sort
candidateLabels = candidateLabels.sortBy(function(s) {
  return s.length * -1;
});

var locatedLabel = candidateLabels.first();
var labelFor = locatedLabel.getAttribute('for');

if ((labelFor == null) && (locatedLabel.hasChildNodes())) {
  // TODO: should find the first form field, not just any node
  return locatedLabel.firstChild;
}

return selenium.browserbot.locationStrategies['id'].call(this, labelFor, inDocument, inWindow);
