// Credit to: http://simonwillison.net/2006/Jan/20/escape/
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
};

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
var labelFor = null;

if (locatedLabel.getAttribute('for')) {
  labelFor = locatedLabel.getAttribute('for');
} else if (locatedLabel.attributes['for']) { // IE
  labelFor = locatedLabel.attributes['for'].nodeValue;
}

if ((labelFor == null) && (locatedLabel.hasChildNodes())) {
  return locatedLabel.getElementsByTagName('button')[0]
    || locatedLabel.getElementsByTagName('input')[0]
    || locatedLabel.getElementsByTagName('textarea')[0]
    || locatedLabel.getElementsByTagName('select')[0];
}

return selenium.browserbot.locationStrategies['id'].call(this, labelFor, inDocument, inWindow);
