component {
	property name='commentService' inject='commentService@cb';
	property name='settingService' inject='settingService@cb';
	property name='mailService' inject='coldbox:plugin:mailService';
	property name='CBHelper' inject='CBHelper@cb';
	property name='renderer' inject='provider:ColdBoxRenderer';
	property name='moduleName' inject='moduleName@CommentEmailer';

	
	//------------------------------------------------------------------------------------------------
	// I fire when the comment is first saved, but if you have moderation on and this person has
	// never commented on your blog nothing will happen here
	//------------------------------------------------------------------------------------------------
	public void function cbui_onCommentPost(event, interceptData) eventPattern="^contentbox-ui" {

		if(interceptData.comment.getCommentId() != "") {
			var comment = commentService.get(interceptData.comment.getCommentId());

			if(!interceptData.moderationResults.moderated) {
				sendMailNotifications(interceptData.comment.getCommentId());
			}
		}
	}
	
	//------------------------------------------------------------------------------------------------
	// This fires when you approve the comment from the admin. Note, if you un-approve and 
	// re-approve a comment, this will fire again.
	//------------------------------------------------------------------------------------------------
	public void function cbadmin_onCommentStatusUpdate(event, interceptData) {
		commentIDList = listToArray(interceptData.commentID);
		if( interceptData.status == 'approve' ) {
			for( var commentID in commentIDList ) {
				sendMailNotifications( commentID );
			}	
		}
	}



	//------------------------------------------------------------------------------------------------
	// Actually send out the E-mails to everyone else who has commented on the same post.
	//------------------------------------------------------------------------------------------------
	private void function sendMailNotifications(required string commentId) {

		var comments = commentService.getAll(listToArray(arguments.commentID), "createdDate asc");
		var settings = settingService.getAllSettings(asStruct=true);

		for(var comment in comments) {
			// Todo: People can only subscribe with blog posts at the moment, there might be a switch added later.
			if(comment.getrelatedContent().getContentType() == 'entry') {
				var results = {};
				var criteria = commentService.newCriteria();
				criteria.eq("isApproved", javaCast("boolean", true));
				criteria.eq("relatedContent.contentID", javaCast("int", comment.getrelatedContent().getContentId() ));
				criteria.ne( "authorEmail", comment.getAuthorEmail() );

				criteria.withProjections(distinct = "authorEmail:email");
				results = criteria.list();

				var bodyTokens = comment.getMemento();
				bodyTokens["commentURL"] = CBHelper.linkComment( comment );
				bodyTokens["contentURL"] = CBHelper.linkContent( comment.getRelatedContent() );
				bodyTokens["contentTitle"] = comment.getParentTitle();

				for(var email in results) {
					log.info("Sending email for moderated Post Id: #comment.getCommentId()# - sending email out to #email#");

					var mail = mailservice.newMail(to = email,
					   from = settings.cb_site_outgoingEmail,
					   subject = "New comment made for post: #bodyTokens.contentTitle#",
					   type = "html",
					   bodyTokens = bodyTokens,
					   server = settings.cb_site_mail_server,
					   username = settings.cb_site_mail_username,
					   password = settings.cb_site_mail_password,
					   port = settings.cb_site_mail_smtp,
					   useTLS = settings.cb_site_mail_tls,
					   useSSL = settings.cb_site_mail_ssl);

					mail.setBody( renderer.get().renderView(view="email_templates/comment_notify", module=moduleName, args={gravatarEmail=comment.getAuthorEmail()}) );
					mailService.send( mail );
				}
			}
		}
	}


}