var locationStrategies = selenium.browserbot.locationStrategies;

return locationStrategies['id'].call(this, locator, inDocument, inWindow)
        || locationStrategies['name'].call(this, locator, inDocument, inWindow)
        || locationStrategies['label'].call(this, locator, inDocument, inWindow)
        || null;
