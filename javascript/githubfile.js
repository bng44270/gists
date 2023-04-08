/*
  Update Files using Github API
  
  Requires webrequest.js (https://gist.github.com/bng44270/61122a1947591d50004fcd9ee72d643d)
  
  Usage:
  
    Usage:
  
    Instantiate the object:
    
      var gh = new GithubFile('API-TOKEN','USERNAME','EMAIL-ADDRESS');

    Get information on a repository entry (returns same object as Github REST API "Get Repository Content"):

      gh.getEntry("<repository-name","<file-path>");

    For details on getEntry return value, see https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#get-repository-content

    To update a file in a repository:

      gh.updateFile("<repository-name>","<file-path>","<file-SHA>","<commit-message>","<new-file-content>");
    
    Note that the <file-SHA> is an element of the object returned by getEntry()
    
*/

class GithubFile {
  constructor(token,username,email) {
    this.USER = username;
    this.EMAIL = email;
    this.TOKEN = token;
  }
  
  async getFile(repo,filepath) {
    var url = "https://api.github.com/repos/" + this.USER + "/" + repo + "/contents" + filepath;
    
    var req = new WebRequest('GET',url);
    
    var resp = await req.response;
    
    return JSON.parse(resp.body);
  }
  
  async UpdateFile(repo,filepath,sha,msg,content) {
    var post = {};
    post['message'] = msg;
    post['committer'] = {};
    post['committer']['name'] = this.USER;
    post['committer']['email'] = this.EMAIL;
    post['content'] = btoa(content);
    post['sha'] = sha;
    
    var headers = {};
    
    headers['Accept'] = 'application/vnd.github+json';
    headers['Authorization'] = 'Bearer ' + this.TOKEN;
    headers['X-GitHub-Api-Version'] = '2022-11-28';
    
    var payload = {
      headers : headers,
      data : JSON.stringify(post)
    };
    
    var url = "https://api.github.com/repos/" + this.USER + "/" + repo + "/contents" + filepath;
    
    var req = new WebRequest('PUT',url,payload);
    
    return await req.response;
  }
}
