<% for column in AppleComment.content_columns %>
<p>
  <b><%= column.human_name %>:</b> <%=h @apple_comment.send(column.name) %>
</p>
<% end %>

<%= link_to 'Edit', :action => 'edit', :id => @apple_comment %> |
<%= link_to 'Back', :action => 'list' %>
