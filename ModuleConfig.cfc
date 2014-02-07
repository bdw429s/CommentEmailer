component {

	this.title 				= "E-mail Comments";
	this.author 			= "Brad Wood";
	this.webURL 			= "http://www.codersrevolution.com";
	this.description 		= "A simple stop gap module to E-mail people of followup comments on blog posts.";
	this.version			= "1.0";

	function configure(){
		
		settings = {
		};
		
		interceptors = [
			{class="#ModuleMapping#.model.CommentEmailer"}
		];
		
		binder.map("moduleName@CommentEmailer").toValue( listLast(ModuleMapping,'/') );

	}
	
}
