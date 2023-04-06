/*
  Update Repository Files using Github API
  
  Requires webrequest.js (https://gist.github.com/bng44270/61122a1947591d50004fcd9ee72d643d)
  
  Usage:
  
    var gh = new GithubFile('API-TOKEN','USERNAME','EMAIL-ADDRESS');
    
    var prFile = gh.getFile('REPOSITORY','FILE-PATH');
    prFile.then(file => {
      var prUpdate = gh.UpdateFile('REPOSITORY','FILE-PATH',file['sha'],'COMMIT-MESSAGE','NEW FILE CONTENT');
      prUpdate.then(resp => {
        if (resp.status == 200) {
          console.log("Successfully update file");
        }
        else {
          console.log("Error updating file");
          console.log(JSON.stringify(resp));
        }
      });
    });
    
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
