class JesseModelUpdate < BaseService
  attr_reader :r

  def initialize
    @r = RAdapter.new
    CsvWriter.run(table: 'metrics',assets: nil)
  end
  def run
    @r = RAdapter.new
    resulVals = @r.jesse_analysis
    JesseCalculator.run
  end

end
