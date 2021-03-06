class AnimalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :index]
  before_action :set_animal, only: [:show, :edit, :update, :destroy, :rating]

  def index
    # @animals = Animal.where.not(latitude: nil, longitude: nil)
      @animals = Animal.all
    if params[:search_address].present?
      @animals = @animals.near(params[:search_address], 2)
    end
    if params[:search_animal].present?
      @animals = @animals.select { |animal| animal.title.downcase.include?(params[:search_animal].downcase) }
    end
    @hash = Gmaps4rails.build_markers(@animals) do |animal, marker|
        marker.lat animal.latitude
        marker.lng animal.longitude
        marker.infowindow render_to_string(partial: "/animals/map_box", locals: { animal: animal })

      end
  end

  def show
    @booking = Booking.new
    # @animal_coordinates = { lat: @animal.latitude, lng: @animal.longitude }
    @hash = Gmaps4rails.build_markers([@animal]) do |animal, marker|
      marker.lat animal.latitude
      marker.lng animal.longitude
    end
  end

  def new
    @animal = Animal.new
  end

  def create
    @animal = Animal.new(animal_params)
    @animal.user = current_user
    if @animal.save
      redirect_to animal_path(@animal)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @animal.update(animal_params)
    redirect_to animal_path(@animal)
  end

  def destroy
    @animal.destroy
    redirect_to animals_path
  end

  private

  def set_animal
    @animal = Animal.find(params[:id])
  end

  def animal_params
    params.require(:animal).permit(:title, :address, :description, :daily_price, :photo, :photo_cache)
  end

end
