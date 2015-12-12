package core;

public class ExampleCyclomaticComplexity {

	public boolean doesContainJamesOrJoey(String[] names) {
	        for ( String name : names ) {
	                if ( name == "James" ) {
	                    return true;
	                }
	                else if ( name == "Joey" ) {
                        return true;
	                }
	                else {
	                	System.out.println("Name is: " + name);
	                }
	        }	        
	        return false;
	}

}