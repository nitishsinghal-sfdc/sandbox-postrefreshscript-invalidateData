/**
* @author Nitish Singhal (nitishsinghal007@gmail.com)
* @date 15th October 2019
* @description Runs Batch class to invalidate emails and phone fields for given objects.
*
* CHANGE LOG
**/
public class SandboxPostRefreshScript implements SandboxPostCopy {

// The method that is executed after refresh
public void runApexClass(SandboxContext context) {

    // Kick off the batch chain to execute the tasks
    Database.executeBatch(new SandboxPostRefreshScriptBatch());
    }
}