var optionElements = inDocument.getElementsByTagName('option');
var locatedOption = $A(optionElements).find(function(candidate){
  return (PatternMatcher.matches(locator, getText(candidate)));
});
return locatedOption ? locatedOption.parentNode : null;
