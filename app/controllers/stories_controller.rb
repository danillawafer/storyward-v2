class StoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @book_nodes = Node.where(parent_node: 0)
    @book_nodes = @book_nodes.map {|node| {id: node.id}}
    @nodes = { children: @book_nodes }.to_json
  end

  def new
    @parent_node = params[:id] if params[:id]
    @story = Story.new
    @story.build_node
  end

  def show 
    @node = Node.find(params[:id])
    @story = build_chain(@node).reverse
  end

  def create
    story_params = {}
    
    if params[:story][:upload]
      uploaded_io = params[:story][:upload]
      filetype = uploaded_io.original_filename.split(".").last.downcase
      if ["pdf", "doc", "docx", "txt", "rtf", "pages", "epub", "mobi", "html", "gdoc", "md"].include?(filetype)
        File.open(Rails.root.join('public', 'uploads',
          uploaded_io.original_filename), 'w') do |file|
          file.write(uploaded_io.read)
        end
      end
      
    end

    story_params[:title] = node_params[:title]
    @story = Story.new(story_params)
    @story.user = current_user
    @story.node = Node.create(node_params)
    @story.node.user = current_user
    if @story.save
      redirect_to story_path(@story.node), :notice => "#{@story.title} was created successfully."
    else
      render :new, :alert => "Story could not be saved. Please see the errors below."
    end
  end

  def update
    @story = Story.find(params[:id])
    if @story.update(node_params)
      redirect_to @story, :notice => "#{@story.title} was updated succesfully."
    else
      render :update, :alert => "Updates could not be saved. Please see the errors below."
    end
  end

  def destroy
    story = Story.find(params[:id])
    story.destroy
    redirect_to stories_path, :notice => "Story removed successfully."
  end

  private

  def node_params
    params.require(:node).permit(:title, :content, :parent_node)
  end
end
