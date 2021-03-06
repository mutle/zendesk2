class Zendesk2::Client::TopicComment < Zendesk2::Model
  extend Zendesk2::Attributes

  PARAMS = %w[id topic_id user_id body informative]

  identity  :id,          type: :integer # ro[integer] mandatory [yes] Automatically assigned upon creation
  attribute :url,         type: :string  # ro[yes]     mandatory [no]  The API url of this topic comment
  attribute :topic_id,    type: :integer # ro[no]      mandatory [yes] The id of the topic this comment was made on
  attribute :user_id,     type: :integer # ro[no]      mandatory [yes] The id of the user making the topic comment
  attribute :body,        type: :string  # ro[no]      mandatory [yes] The comment body
  attribute :informative, type: :boolean # ro[no]      mandatory [no]  If the comment has been flagged as informative
  attribute :attachments, type: :array   # ro[yes]     mandatory [no]  Attachments to this comment as Attachment objects
  attribute :created_at,  type: :date    # ro[yes]     mandatory [no]  The time the topic_comment was created
  attribute :updated_at,  type: :date    # ro[yes]     mandatory [no]  The time of the last update of the topic_comment

  assoc_accessor :user
  assoc_accessor :topic

  def destroy
    requires :identity

    connection.destroy_topic_comment("id" => self.identity, "topic_id" => self.topic_id)
  end

  def save!
    data = if new_record?
             requires :topic_id, :user_id, :body
             connection.create_topic_comment(params).body["topic_comment"]
           else
             requires :identity
             connection.update_topic_comment(params).body["topic_comment"]
           end
    merge_attributes(data)
  end

  def reload
    requires :identity

    if data = collection.get(topic_id, identity)
      new_attributes = data.attributes
      merge_attributes(new_attributes)
      self
    end
  end

  private

  def params
    Cistern::Hash.slice(Zendesk2.stringify_keys(attributes), *PARAMS)
  end
end
