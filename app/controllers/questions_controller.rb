class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  # GET /questions
  # GET /questions.json
  def index

    if params[:search] and params[:type]
      @questions = Question.where("category LIKE ? and (title LIKE ? or quest LIKE ?)","%#{params[:type]}%","%#{params[:search]}%","%#{params[:search]}%")
    elsif params[:type]
      @questions = Question.where("category LIKE ?","%#{params[:type]}%")
    elsif  params[:search]
      @questions = Question.where("title LIKE ? or quest LIKE ?","%#{params[:search]}%","%#{params[:search]}%")
    else
      @questions = Question.all
    end


  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def run
    tmp_file = "#{Rails.root}/tmp/test.py"
    id = 0

    File.open(tmp_file, 'w+') do |f|
      f.write params[:code]
    end

    stdout = with_timeout "python #{tmp_file}", 5
    render plain:stdout
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
      if @question.category.nil?
        @question.category = ""
      end
    end
    # timeout is in seconds
  def with_timeout(cmd, timeout)


    # popen2e combines stdout and stderr into one IO object
    i, oe, t = Open3.popen2e(cmd) # stdin, stdout+stderr, thread
    t[:timed_out] = false
    i.close

    # Purposefully NOT using Timeout.rb because in general it is a dangerous API!
    # http://blog.headius.com/2008/02/rubys-threadraise-threadkill-timeoutrb.html
    Thread.new do
      sleep timeout
      if t.alive?
        suppress(Errno::ESRCH) do # 'No such process' (possible race condition)
          # NOTE: we are assuming the command will create ONE process (not handling subprocs / proc groups)
          Process.kill('TERM', t.pid)
          t[:timed_out] = true
        end
      end
    end

    t.value # wait for process to finish, one way or the other
    out = oe.read(10000)
    out = "*** Empty output ***" if out.nil?
    oe.close

    if t[:timed_out]
      out << "\n" unless out.blank?
      out << "*** Process failed to complete after #{timeout} seconds ***"
    end

    out
  end
    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :quest, :answer,:category)
    end
end
