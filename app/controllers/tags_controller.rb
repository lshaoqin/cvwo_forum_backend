class TagsController < ApplicationController
    def new
        name = params[:name]
        #Check for invalid lengths
        if name.blank?
            render json: {error: 'Blank tags are not allowed.'}, status: :unprocessable_entity
            return
        end
        if name.length > 16
            render json: {error: 'Max tag length is 16 characters'}, status: :unprocessable_entity
            return
        end
        decoded_id = JWT.decode(params[:token], 
                                ENV['VALIDATION_KEY'], 
                                true)[0]['id']
        post_id = params[:post_id]
        post = Post.find(post_id)
        #Determine weight of vote
        weight = (post.user_id == decoded_id) ? 5 : 1
        weight = (params[:positive]) ? weight : -weight
        current_vote = Tag.find_by(name: name, 
                                    user_id: decoded_id,
                                    post_id: post_id)
        @tag = Tag.create(name: name,
                            weight: weight,
                            post_id: post_id,
                            user_id: decoded_id)
        if @tag.save
            #delete/overwrite the old vote, if any
            if current_vote
                current_vote.destroy
            end
            render json: @tag, status: :created
        else
            render json: {error: 'An error has occurred. Please try again!'}, status: :unprocessable_entity
        end
    end

    def revoke
        name = params[:name]
        decoded_id = JWT.decode(params[:token], 
                                ENV['VALIDATION_KEY'], 
                                true)[0]['id']
        post_id = params[:post_id]
        current_vote = Tag.find_by(name: name, 
            user_id: decoded_id,
            post_id: post_id)

        if current_vote.destroy
            render json:{}, status: 200
        else
            render json: {error: 'An error has occurred. Please try again!'}, status: :unprocessable_entity
        end
    end
end
