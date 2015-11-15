package core;

import analyzer.InitShizzle;
import analyzer.AnalyzeShizzle;

// Testing with regular expressions

/*
 * These are comments too.
 * Too.
 */

 // Inconsistent comment.

 /* Same here
  ********** Blah
*** Blarg
  */

         //This is also comment.

				//And this.

/**
 * What goes wrong here?
 * @param con SSConnection for transactions
 */

public class Main {
	
	// Some crap
	public static void main(String[] args) {
		
		InitShizzle init = new InitShizzle();
		AnalyzeShizzle analyze = new AnalyzeShizzle();
		
		int initializer = init.doInitializeShizzle("hoi"); // Also comment
		String analyzer = "not initialized";
		
		if (initializer == 1) {
			analyzer = analyze.doAnalyzeShizzle("analyze");
		}
		
		int doingTheSameThing;
		
		doingTheSameThing = 1;
		doingTheSameThing = 2;
		doingTheSameThing = 3;
		doingTheSameThing = 4;
		doingTheSameThing = 5;
		doingTheSameThing = 6;
		
		System.out.println(doingTheSameThing);
		
		doingTheSameThing = 1;
		doingTheSameThing = 2;
		doingTheSameThing = 3;
		doingTheSameThing = 4;
		doingTheSameThing = 5;
		doingTheSameThing = 6;
		
		doingTheSameThing = 1;
		
		doingTheSameThing = 1;
		
		System.out.println(doingTheSameThing); /* Seriously */ doingTheSameThing = 7;
		
		doingTheSameThing = 1;
		doingTheSameThing = 2;
		doingTheSameThing = 3;
		doingTheSameThing = 4;
		doingTheSameThing = 5;
		doingTheSameThing = 6;
		
		System.out.println("Is the program analyzed: " + analyzer);
	}

	public String fakeMethod() {
		String fake = "this is stupid";
		return fake;
	}
}