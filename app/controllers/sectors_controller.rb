class SectorsController < ApplicationController
  before_action :set_sector, only: [:show, :edit, :update, :destroy, :companies_ratio]

  # GET /sectors
  # GET /sectors.json
  def index
    @sectors = Sector.includes(:industries, :companies)
  end

  # GET /sectors/1
  # GET /sectors/1.json
  def show
    @industries = @sector.industries
  end

  # GET /sectors/new
  def new
    @sector = Sector.new
  end

  def companies_ratio
    if @sector.present?
      sectors = @sector.companies.joins(:industry).where("industries.name != 'n/a'").group('industries.name').count
    else
      sectors = Company.joins(:sector).where("sectors.name != 'n/a'").group('sectors.name').count
    end

    respond_to do |format|
      format.json { render json:  sectors.sort_by {|_, v| v}.map { |k, v| {name: k, y: v} } }
    end
  end

  # GET /sectors/1/edit
  def edit
  end

  # POST /sectors
  # POST /sectors.json
  def create
    @sector = Sector.new(sector_params)

    respond_to do |format|
      if @sector.save
        format.html { redirect_to @sector, notice: 'Sector was successfully created.' }
        format.json { render :show, status: :created, location: @sector }
      else
        format.html { render :new }
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sectors/1
  # PATCH/PUT /sectors/1.json
  def update
    respond_to do |format|
      if @sector.update(sector_params)
        format.html { redirect_to @sector, notice: 'Sector was successfully updated.' }
        format.json { render :show, status: :ok, location: @sector }
      else
        format.html { render :edit }
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sectors/1
  # DELETE /sectors/1.json
  def destroy
    @sector.destroy
    respond_to do |format|
      format.html { redirect_to sectors_url, notice: 'Sector was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sector
      if params[:id].present?
        @sector = Sector.includes(:companies).find(params[:id])
      elsif params[:sector_id].present?
        @sector = Sector.find(params[:sector_id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sector_params
      params.require(:sector).permit(:name)
    end
end
