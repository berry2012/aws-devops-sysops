#!/usr/bin/env python3

import boto3
import argparse
import json
from datetime import datetime
from typing import List, Dict, Any

def get_py39_functions(client, region: str) -> List[Dict[str, Any]]:
    """Get all Python 3.9 functions in a region"""
    try:
        response = client.list_functions()
        return [f for f in response['Functions'] if f['Runtime'] == 'python3.9']
    except Exception as e:
        print(f"Error listing functions in {region}: {e}")
        return []

def update_function(client, function_name: str, dry_run: bool) -> Dict[str, Any]:
    """Update function runtime with error handling"""
    result = {
        'function': function_name,
        'success': False,
        'error': None,
        'original_runtime': 'python3.9'
    }
    
    if dry_run:
        result['success'] = True
        result['action'] = 'DRY RUN - Would update to python3.13'
        return result
    
    try:
        client.update_function_configuration(
            FunctionName=function_name,
            Runtime='python3.13'
        )
        result['success'] = True
        result['action'] = 'Updated to python3.13'
    except Exception as e:
        result['error'] = str(e)
    
    return result

def rollback_function(client, function_name: str) -> bool:
    """Rollback function to original runtime"""
    try:
        client.update_function_configuration(
            FunctionName=function_name,
            Runtime='python3.9'
        )
        return True
    except Exception as e:
        print(f"Rollback failed for {function_name}: {e}")
        return False

def generate_report(results: List[Dict[str, Any]], output_file: str = None):
    """Generate detailed report"""
    report = {
        'timestamp': datetime.now().isoformat(),
        'summary': {
            'total': len(results),
            'successful': sum(1 for r in results if r['success']),
            'failed': sum(1 for r in results if not r['success'])
        },
        'details': results
    }
    
    if output_file:
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        print(f"Report saved to {output_file}")
    else:
        print(json.dumps(report, indent=2))

def main():
    parser = argparse.ArgumentParser(description='Update Lambda Python 3.9 functions to 3.13')
    parser.add_argument('--regions', nargs='+', default=['eu-west-1'], help='AWS regions')
    parser.add_argument('--profile', help='AWS profile')
    parser.add_argument('--dry-run', action='store_true', help='Test mode without changes')
    parser.add_argument('--rollback', action='store_true', help='Rollback to python3.9')
    parser.add_argument('--report', help='Output report file')
    
    args = parser.parse_args()
    
    session = boto3.Session(profile_name=args.profile) if args.profile else boto3.Session()
    all_results = []
    
    if args.profile:
        print(f"Using AWS profile: {args.profile}")
    
    if args.dry_run:
        print("DRY RUN MODE - No changes will be made")
    
    for region in args.regions:
        print(f"\nProcessing region: {region}")
        client = session.client('lambda', region_name=region)
        
        functions = get_py39_functions(client, region)
        if not functions:
            print(f"No Python 3.9 functions found in {region}")
            continue
        
        print(f"Found {len(functions)} Python 3.9 functions")
        
        for func in functions:
            function_name = func['FunctionName']
            print(f"Processing: {function_name}")
            
            if args.rollback:
                success = rollback_function(client, function_name)
                result = {
                    'region': region,
                    'function': function_name,
                    'success': success,
                    'action': 'Rolled back to python3.9' if success else 'Rollback failed'
                }
            else:
                result = update_function(client, function_name, args.dry_run)
                result['region'] = region
            
            all_results.append(result)
            status = "✓" if result['success'] else "✗"
            print(f"{status} {result.get('action', result.get('error', 'Unknown'))}")
    
    print(f"\nCompleted. Total: {len(all_results)}, Success: {sum(1 for r in all_results if r['success'])}, Failed: {sum(1 for r in all_results if not r['success'])}")
    
    if args.report or not args.dry_run:
        generate_report(all_results, args.report)

if __name__ == "__main__":
    main()