UI.registerHelper 'commentDate', (date) ->
  if date
    dateObj = new Date(date)
    return $.timeago(dateObj)
  "some time ago"

#
#  Commenting Widget
#

Template.comments.rendered = ->
  if Meteor.user()
    commentable = @data
    _.each commentable.comments(), (comment) ->
      comment.clearNotification()

  $('#editor').jqte
    sub: false,
    sup: false,
    strike: false,
    remove: false,
    source: false,
    rule: false

Template.comments.helpers
  comments: ->
    _.sortBy @comments(), 'createdAt'

Template.comments.events
  'click .add-comment': (e) ->
    username = "Unknown"
    user = Meteor.user()
    if user.emails then username = user.emails[0].address
    if user.username then username = user.username
    if user.profile and user.profile.name then username = user.profile.name
    if user.profile and user.profile.firstName then username = user.profile.firstName + " " + Meteor.user().profile.lastName

    comment =
      associationId: @id
      userId: Meteor.userId()
      username: username
      comment: $('#editor').val()
      path: Router.current().path
      notify: []
      tags: []

    # Allow custom modification
    comment = @before_comment comment

    # Add every other commentor above to notify list
    _.each @comments(), (e) ->
      comment.notify.push e.userId

    # Remove duplicates
    comment.notify = _.uniq comment.notify

    # Remove this user
    comment.notify = _.reject comment.notify, (e) ->
      e is Meteor.userId()

    # Add the comment
    Comment.create comment

    # Clear values
    $('#editor').jqteVal ''
