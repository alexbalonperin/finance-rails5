class PotentialInvestmentsController < ApplicationController
  before_action :set_potential_investment, only: [:show, :edit, :update, :destroy]

  # GET /potential_investments
  # GET /potential_investments.json
  def index
    @potential_investments = PotentialInvestment.sorted_latest
    @promising_investments = PotentialInvestment.sorted_latest(type = 'promising')
  end

  # GET /potential_investments/1
  # GET /potential_investments/1.json
  def show
  end

  # GET /potential_investments/new
  def new
    @potential_investment = PotentialInvestment.new
  end

  # GET /potential_investments/1/edit
  def edit
  end

  # POST /potential_investments
  # POST /potential_investments.json
  def create
    @potential_investment = PotentialInvestment.new(potential_investment_params)

    respond_to do |format|
      if @potential_investment.save
        format.html { redirect_to @potential_investment, notice: 'Potential investment was successfully created.' }
        format.json { render :show, status: :created, location: @potential_investment }
      else
        format.html { render :new }
        format.json { render json: @potential_investment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /potential_investments/1
  # PATCH/PUT /potential_investments/1.json
  def update
    respond_to do |format|
      if @potential_investment.update(potential_investment_params)
        format.html { redirect_to @potential_investment, notice: 'Potential investment was successfully updated.' }
        format.json { render :show, status: :ok, location: @potential_investment }
      else
        format.html { render :edit }
        format.json { render json: @potential_investment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /potential_investments/1
  # DELETE /potential_investments/1.json
  def destroy
    @potential_investment.destroy
    respond_to do |format|
      format.html { redirect_to potential_investments_url, notice: 'Potential investment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_potential_investment
      @potential_investment = PotentialInvestment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def potential_investment_params
      params.fetch(:potential_investment, {})
    end
end
