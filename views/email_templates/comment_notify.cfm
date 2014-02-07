<cfoutput>
    <cfset ETH = getPlugin( plugin="EmailTemplateHelper", module="contentbox" )>
    #ETH.author( email=args.gravatarEmail, content="
        <strong>@author@</strong> has posted a new comment on the page:<br /> <a href='@contentURL@'>@contentTitle@<a/>
    ")#
    #ETH.heading( content="Comment" )#
    #ETH.text( content="@content@", callout="true" )#
    #ETH.buttonBar(
        [
            {href="@commentURL@",image="comment-alt.png",text="View Comment"}
        ]
    )#
    #ETH.heading( content="Comment Details" )#
    #ETH.text('
        <table cellpadding="3" cellspacing="3">
            <tbody>
                <tr>
                    <td><strong>Author:</strong></td>
                    <td>@author@</td>
                </tr>
                <tr>
                    <td><strong>Author URL:</strong></td>
                    <td><a href="@authorURL@">@authorURL@</a></td>
                </tr>
            </tbody>
        </table>
    ')#
</cfoutput>