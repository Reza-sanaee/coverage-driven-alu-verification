"""Compile, elaborate and run ALU tests using a licensed Questa installation."""
from pathlib import Path
import argparse,subprocess,shutil,os,re,json
ROOT=Path(__file__).resolve().parent
def execute(args,cwd,log):
    r=subprocess.run(list(map(str,args)),cwd=cwd,text=True,encoding='utf8',errors='replace',stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    log.write_text(r.stdout,encoding='utf8')
    if r.returncode or re.search(r'\*\* (?:Error|Fatal)',r.stdout):
        raise RuntimeError(f"Tool failed; inspect {log}")
    return r.stdout
def run(test,seed):
    result=ROOT/'results'/f'{test}_{seed}';result.mkdir(parents=True,exist_ok=True)
    build=ROOT/'build'/f'{test}_{seed}';build.mkdir(parents=True,exist_ok=True);lib=build/'work'
    if not lib.exists():execute([TOOLS['vlib'],lib],ROOT,result/'library.log')
    sources=[ROOT/'hvl/parameter_packages/parameters.sv',ROOT/'hvl/interface_packages/alu_in_pkg/ALU_in_if.sv',ROOT/'hvl/interface_packages/alu_out_pkg/ALU_out_if.sv',ROOT/'hdl/alu_multi_cycle.sv',ROOT/'hvl/class_pkg.sv']+list((ROOT/'hvl/tests').glob('*.sv'))+[ROOT/'hvl/top.sv']
    args=[TOOLS['vlog'],'-sv','-work',lib,'+incdir+'+str(ROOT/'hvl')]
    define={'test_mid':'TEST_MID','test_mix':'TEST_MIX','random_test':'TEST_RANDOM'}.get(test)
    if define:args+=['+define+'+define]
    execute(args+sources,ROOT,result/'compile.log')
    execute([TOOLS['vlog'],'-sv','-cover','fsb','-work',lib,ROOT/'hdl/alu_multi_cycle.sv'],ROOT,result/'rtl_coverage_compile.log')
    execute([TOOLS['vopt'],'-work',lib,'+acc','top','-o','validated_top'],ROOT,result/'elaborate.log')
    # Relative paths avoid legacy Windows simulator argument parsing of spaces.
    command=f'onfinish stop;coverage attribute -name TESTNAME -value {test}{seed};run -all;coverage save {test}_{seed}.ucdb;quit -f'
    output=execute([TOOLS['vsim'],'-c','-sv_seed',str(seed),'-coverage','-lib',os.path.relpath(lib,result),'validated_top','-do',command],result,result/'simulation.log')
    m=re.search(r'SCOREBOARD: passed=(\d+) aborted=(\d+) failed=(\d+) expected_pending=(\d+) actual_pending=(\d+)',output)
    if not m:raise RuntimeError('Scoreboard summary missing')
    summary=dict(zip(['passed','aborted','failed','expected_pending','actual_pending'],map(int,m.groups())))
    if summary['failed'] or summary['expected_pending'] or summary['actual_pending']:raise RuntimeError(f'Incomplete or failed test: {summary}')
    execute([TOOLS['vcover'],'report','-details','-cvg',result/f'{test}_{seed}.ucdb'],ROOT,result/'functional_coverage.txt')
    (result/'summary.json').write_text(json.dumps(summary,indent=2),encoding='utf8')
    print(test,summary)
    return result/f'{test}_{seed}.ucdb'
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--test',choices=['all','test_mid','test_high','test_mix','random_test'],default='all');parser.add_argument('--seed',type=int,default=42);args=parser.parse_args()
    TOOLS={name:shutil.which(name) for name in ['vlib','vlog','vopt','vsim','vcover']}
    missing=[name for name,value in TOOLS.items() if not value]
    if missing:parser.error('Add Questa tools to PATH: '+', '.join(missing))
    tests=['test_mid','test_high','test_mix','random_test'] if args.test=='all' else [args.test]
    databases=[run(test,args.seed) for test in tests]
    if len(databases)>1:
        combined=ROOT/'results'/f'combined_{args.seed}';combined.mkdir(parents=True,exist_ok=True)
        execute([TOOLS['vcover'],'merge','-testassociated','-out',combined/'merged.ucdb']+databases,ROOT,combined/'merge.log')
        execute([TOOLS['vcover'],'report','-details','-cvg',combined/'merged.ucdb'],ROOT,combined/'functional_coverage.txt')
        execute([TOOLS['vcover'],'ranktest','-iterative','-cvg','-stats=none','-rankfile',combined/'vsim.rank','-log',combined/'ranked_tests.txt']+databases,ROOT,combined/'ranking.log')
