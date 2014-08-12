Meteor.publish 'comments', (associationId) ->
  Comment.find
    associationId: associationId
  , sort:
      createdAt: 1

Meteor.publish 'unreadComments', ->
  if @userId
    Comment.find({'notify': { $in: [@userId]}})
  else
    @ready()

Meteor.publish 'commentsUser', ->
  Meteor.users.find _id: @userId,
    fields: profile: 1
