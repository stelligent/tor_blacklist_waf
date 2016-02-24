import java.util.Map;

import org.jruby.Ruby;
import org.jruby.embed.PathType;
import org.jruby.embed.ScriptingContainer;

import com.amazonaws.services.lambda.runtime.Context;


public class JRubyHandlerWrapper {

  static {
    Ruby.newInstance();
  }

  @SuppressWarnings("rawtypes")
  public String handler(Map lambdaInputMap, Context lambdaContext) throws Exception {

    ScriptingContainer jrubyScriptingContainer = new ScriptingContainer();
    jrubyScriptingContainer.put("$lambdaInputMap", lambdaInputMap);
    jrubyScriptingContainer.put("$lambdaLogger", lambdaContext.getLogger());
    jrubyScriptingContainer.put("$lambdaContext", lambdaContext);

    // uploaded zip is extracted to /var/task directory
    jrubyScriptingContainer.setCurrentDirectory("/var/task");

    Object result = jrubyScriptingContainer.runScriptlet(PathType.CLASSPATH,
                                                         rubyFileName);

    return result == null ? null : result.toString();
  }

  private static final String rubyFileName = "handler.rb";
}