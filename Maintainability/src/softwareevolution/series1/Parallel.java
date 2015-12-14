package softwareevolution.series1;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

import org.rascalmpl.ast.FunctionDeclaration.Default;
import org.rascalmpl.interpreter.ConsoleRascalMonitor;
import org.rascalmpl.interpreter.Evaluator;
import org.rascalmpl.interpreter.IEvaluator;
import org.rascalmpl.interpreter.env.GlobalEnvironment;
import org.rascalmpl.interpreter.env.ModuleEnvironment;
import org.rascalmpl.interpreter.load.StandardLibraryContributor;
import org.rascalmpl.interpreter.result.OverloadedFunction;
import org.rascalmpl.interpreter.result.RascalFunction;
import org.rascalmpl.interpreter.result.Result;
import org.rascalmpl.value.IList;
import org.rascalmpl.value.IString;
import org.rascalmpl.value.IValue;
import org.rascalmpl.value.IValueFactory;
import org.rascalmpl.value.type.Type;
import org.rascalmpl.value.type.TypeFactory;
import org.rascalmpl.values.ValueFactoryFactory;

public class Parallel {

	private IValueFactory vf;
	private final TypeFactory tf = TypeFactory.getInstance();

	public Parallel(IValueFactory vf) {
		this.vf = vf;
	}

	public IString hi(IString name) {
		return vf.string("Hi " + name.getValue());
	}

	IEvaluator<Result<IValue>> getDefaultEvaluator(PrintWriter stdout, PrintWriter stderr) {
		GlobalEnvironment heap = new GlobalEnvironment();
		ModuleEnvironment root = heap.addModule(new ModuleEnvironment(ModuleEnvironment.SHELL_MODULE, heap));
		IValueFactory vf = ValueFactoryFactory.getValueFactory();
		Evaluator evaluator = new Evaluator(vf, stderr, stdout, root, heap);
		evaluator.addRascalSearchPathContributor(StandardLibraryContributor.getInstance());
		evaluator.setMonitor(new ConsoleRascalMonitor());
		return evaluator;
	}

	public RascalFunction copyFunction(RascalFunction rf) {
		StringWriter out = new StringWriter();
		StringWriter err = new StringWriter();
		IEvaluator<Result<IValue>> eval = getDefaultEvaluator(new PrintWriter(out), new PrintWriter(err));
		return new RascalFunction(eval, (Default) rf.getAst(), false, rf.getEnv(), eval.__getAccumulators());
	}

	public IList hello(IString name, IValue function) throws InterruptedException {
		final RascalFunction rf = (RascalFunction) ((OverloadedFunction) function).getFunctions().get(0);
		Type[] actualTypes = new Type[] { tf.stringType() };
		List<IString> result = new ArrayList<>();
		Thread t = new Thread(new Runnable() {

			@Override
			public void run() {
				IString string = vf.string("1 " + name.getValue());
				IString fResult = (IString) copyFunction(rf).call(actualTypes, new IValue[] { string }, null)
						.getValue();
				synchronized (Parallel.this) {
					result.add(fResult);
				}
			}
		});
		Thread t2 = new Thread(new Runnable() {

			@Override
			public void run() {
				IString string = vf.string("2 " + name.getValue());
				IString fResult = (IString) copyFunction(rf).call(actualTypes, new IValue[] { string }, null)
						.getValue();
				synchronized (Parallel.this) {
					result.add(fResult);
				}
			}
		});
		Thread t3 = new Thread(new Runnable() {

			@Override
			public void run() {
				IString string = vf.string("3 " + name.getValue());
				IString fResult = (IString) copyFunction(rf).call(actualTypes, new IValue[] { string }, null)
						.getValue();
				synchronized (Parallel.this) {
					result.add(fResult);
				}
			}
		});

		t.start();
		t2.start();
		t3.start();

		t.join();
		t2.join();
		t3.join();
		return vf.list((IString[]) result.toArray(new IString[result.size()]));
	}
}
