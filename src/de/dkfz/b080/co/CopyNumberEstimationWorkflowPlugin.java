package de.dkfz.b080.co;

import de.dkfz.roddy.plugins.BasePlugin;

/**

 * TODO Recreate class. Put in dependencies to other workflows, descriptions, capabilities (like ui settings, components) etc.
 */
public class CopyNumberEstimationWorkflowPlugin extends BasePlugin {

    public static final String CURRENT_VERSION_STRING = "1.0.190";
    public static final String CURRENT_VERSION_BUILD_DATE = "Wed Jan 13 17:18:46 CET 2016";

    @Override
    public String getVersionInfo() {
        return "Roddy plugin: " + this.getClass().getName() + ", V " + CURRENT_VERSION_STRING + " built at " + CURRENT_VERSION_BUILD_DATE;
    }
}