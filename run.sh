echo 'main.tex should contain all tex code, no includes or iputs to other tex files'
AUX_FILE=main.aux BIB_STYLE=ama ./run_submission_build.sh main.tex submission_build
