if (locator == '*') {
  return selenium.browserbot.locationStrategies['xpath'].call(this, "//input[@type='submit']", inDocument, inWindow)
}
var buttons = inDocument.getElementsByTagName('button');
var inputs = inDocument.getElementsByTagName('input');
var result = $A(inputs).concat($A(buttons)).find(function(candidate){
	var type = candidate.getAttribute('type');
	if (type == 'submit' || type == 'image'  || type == 'button') {
		var matches_id = PatternMatcher.matches(locator, candidate.id);
		var matches_value = PatternMatcher.matches(locator, candidate.value);
		var matches_html = PatternMatcher.matches(locator, candidate.innerHTML);
		var matches_alt = PatternMatcher.matches(locator, candidate.alt);
		if (matches_id || matches_value || matches_html || matches_alt) {
			return true;
		}
	}
	return false;
});
return result;
