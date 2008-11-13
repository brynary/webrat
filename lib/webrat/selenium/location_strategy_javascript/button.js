if (locator == '*') {
  return selenium.browserbot.locationStrategies['xpath'].call(this, "//input[@type='submit']", inDocument, inWindow)
}
var inputs = inDocument.getElementsByTagName('input');
return $A(inputs).find(function(candidate){
  inputType = candidate.getAttribute('type');
  if (inputType == 'submit' || inputType == 'image') {
    var buttonText = $F(candidate);
    return (PatternMatcher.matches(locator, buttonText));
  }
  return false;
});
