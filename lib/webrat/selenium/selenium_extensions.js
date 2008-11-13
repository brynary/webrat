PatternMatcher.strategies['evalregex'] = function(regexpString) {
  this.regexp = eval(regexpString);
  this.matches = function(actual) {
    return this.regexp.test(actual);
  };
};