class AirBnb < Sinatra::Base

  get "/" do
    redirect to "/spaces"
  end

  get "/spaces" do
    if params[:available_from]
      @spaces = Space.all(:available_from.lte => params[:available_from], :available_to.gte => params[:available_to])
    else
      @spaces = Space.all(order: [:price.asc])
    end
    erb :"spaces/index"
  end

  get "/spaces/new" do
    erb :"spaces/new"
  end

  post "/spaces" do
    space_params = {user: current_user,
                         name: params[:name],
                         description: params[:description],
                         price: params[:price],
                         available_from: params[:available_from],
                         available_to: params[:available_to]}
    space = Space.authenticate(space_params)
    if space.id.nil?
      flash[:errors] = space.errors.full_messages
      redirect to "/spaces/new"
    else
      redirect to "/spaces"
    end
  end

  get "/spaces/:id" do
    if current_user
      @space = Space.first(id: params[:id])
      bookings = Booking.all(space_id: @space.id, status: "confirmed")
      @bookings_dates = bookings.map {|booking| booking.date.strftime("%Y-%m-%d")}
      @available_from = [@space.available_from, Date.today].max
      erb :"spaces/space"
    else
      redirect to "/sessions/new"
    end
  end
end
