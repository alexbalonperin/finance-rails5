class HistoricalDataController < ApplicationController
  before_action :load_company
  before_action(only: [:list, :prices]) {  sanitize_order_params(HistoricalDatum) }
  before_action :set_historical_datum, only: [:show, :edit, :update, :destroy]

  # GET /historical_data
  # GET /historical_data.json
  def index
  end

  def list
    @historical_data = @company.historical_data
                           .limit(params[:limit])
                           .offset(params[:offset])
                           .order("#{@sort || 'trade_date'} #{@order}")
    @count = @company.historical_data.count
    respond_to do |format|
      format.json { render json: { :total => @count,
                                    :rows => @historical_data } }
    end
  end

  def prices
    historical_data = @company.historical_data
                           .order("#{@sort || 'trade_date'} #{@order || 'desc'}")
                           .limit(params[:n_days])
    result = historical_data.map { |data| [data.trade_date_as_timestamp, data.adjusted_close.to_f] }
                 .sort_by { |el| el[0] }
    respond_to do |format|
      format.json { render json: result }
    end
  end

  # GET /historical_data/1
  # GET /historical_data/1.json
  def show
  end

  # GET /historical_data/new
  def new
    @historical_datum = @company.historical_data.new
  end

  # GET /historical_data/1/edit
  def edit
  end

  # POST /historical_data
  # POST /historical_data.json
  def create
    @historical_datum = @company.historical_data.new(historical_datum_params)

    respond_to do |format|
      if @historical_datum.save
        format.html { redirect_to @historical_datum, notice: 'Historical datum was successfully created.' }
        format.json { render :show, status: :created, location: @historical_datum }
      else
        format.html { render :new }
        format.json { render json: @historical_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /historical_data/1
  # PATCH/PUT /historical_data/1.json
  def update
    respond_to do |format|
      if @historical_datum.update(historical_datum_params)
        format.html { redirect_to [@company, @historical_datum], notice: 'Historical datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @historical_datum }
      else
        format.html { render :edit }
        format.json { render json: @historical_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /historical_data/1
  # DELETE /historical_data/1.json
  def destroy
    @historical_datum.destroy
    respond_to do |format|
      format.html { redirect_to company_historical_data_url, notice: 'Historical datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_historical_datum
      @historical_datum = @company.historical_data.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def historical_datum_params
      params.require(:historical_datum).permit(:trade_date, :open, :high, :low, :close, :volume, :adjusted_close, :company_id)
    end

    def load_company
      @company = Company.find(params[:company_id])
    end
end
